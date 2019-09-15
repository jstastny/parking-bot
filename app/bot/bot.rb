class Bot < SlackRubyBot::Bot

  match /^\s*capacity\s*(?<date>.*)/i do |client, data, match|
    date = Bot.parse_user_date(match[:date], client, data)
    if date

      reservations, available_spots = ReservationService.new.capacity(date)
      message = "Capacity on #{Bot.format_date(date)}:\n"
      unless available_spots.empty?
        message += ":tada: There #{available_spots.count == 1 ? 'is' : 'are'} #{available_spots.count} available " +
          "#{'spot'.pluralize(available_spots.count)}: #{available_spots.map(&:name).to_sentence}.\n"
      else
        message += ":crying_cat_face: There are unfortunately no more available parking spots.\n"
      end
      unless reservations.empty?
        message += "There are following reservations:\n"
        reservations.each do |reservation|
          message += " • Parking spot #{reservation.parking_spot.name} reserved by #{reservation.user.display_name}\n"
        end
      end

      client.say(text: message, channel: data.channel)
    end

  end

  match /^\s*reserve\s?(spot (?<spot>[0-9]+))?\s?(?<date>.*)/i do |client, data, match|
    user = Bot.find_or_create_user(data.user, client)
    date = Bot.parse_user_date(match[:date], client, data)
    spot_name = match[:spot]
    if date
      begin
        reservation = ReservationService.new.create_reservation(user.id, date, date, parking_spot_name: spot_name)
        client.say(
          text: ":tada: I have reserved parking spot *#{reservation.parking_spot.name}* for you on: #{Bot.format_date(date)}. ",
          channel: data.channel
        )

      rescue ReservationService::NoAvailableParkingSpots
        message = if spot_name
                    ":crying_cat_face: Sorry, the parking spot #{spot_name} is not available on #{Bot.format_date(date)}."
                  else
                    ":crying_cat_face: Sorry, there are no available parking spots on #{Bot.format_date(date)}."
                  end
        client.say(
          text: message,
          channel: data.channel
        )
      end
    end
  end

  match /^\s*cancel\s?(?<date>.*)/i do |client, data, match|
    user = Bot.find_or_create_user(data.user, client)
    date = Bot.parse_user_date(match[:date], client, data)
    if date


      reservations = Reservation.on_date(date).where(user: user)

      if reservations.empty?
        message = "There are no reservations for you on #{Bot.format_date(date)}. Nothing to cancel."
      else
        parking_spot_names = reservations.map(&:parking_spot).map(&:name)
        reservations.delete_all
        message = "I have cancelled all your #{'reservation'.pluralize(parking_spot_names.count)} on #{Bot.format_date(date)}. " +
          "You have freed parking #{'spot'.pluralize(parking_spot_names.count)} #{parking_spot_names.to_sentence}."
      end

      client.say(text: message, channel: data.channel)
    end
  end

  help do
    title 'Parking Bot'
    desc 'I can reserve parking spots at Saldova like nobody else.'

    command 'reserve <date>' do
      desc 'Reserves a parking spot on given day for you. If no date is given, today is used.'
    end

    command 'reserve spot <spot number> <date>' do
      desc 'Reserves specific parking spot on given day for you. If no date is given, today is used. For example `reserve spot 12 on Saturday`'
    end

    command 'capacity <date>' do
      desc 'Tells you the capacity of the parking lot for the given day. If no date is given, today is used.'
    end

    command 'cancel <date>' do
      desc 'Cancels all your reservations on the given day. If no date is given, today is used.'
    end
  end

  def self.find_or_create_user(slack_id, slack_client)
    User.find_or_create_by!(slack_id: slack_id) do |user|
      user.display_name = slack_client.web_client.users_info(user: slack_id)['user']['real_name']
    end
  end

  def self.parse_user_date(date_str, client, data)
    puts "Current timezone: #{Time.zone}"
    if date_str.present?
      parsed = Chronic.parse(date_str)
      unless parsed
        client.say(channel: data.channel, text: "Sorry <@#{data.user}>, I don't understand the date `#{date_str}`!")
        return nil
      end

      parsed.to_date
    else
      Date.today
    end
  end

  def self.format_date(date)
    date.strftime('%A, %B %-d, %Y')
  end
end
