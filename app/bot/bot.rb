class Bot < SlackRubyBot::Bot
  match /capacity\s*(?<date>.*)/i do |client, data, match|
    date = Bot.parse_user_date(match[:date])

    reservations, available_spots = ReservationService.new.capacity(date)
    message = "Capacity on #{Bot.format_date(date)}:\n"
    unless available_spots.empty?
      message += ":tada: There #{available_spots.count == 1 ? 'is' : 'are'} #{available_spots.count} available " +
          "#{'spot'.pluralize(available_spots.count)}: #{available_spots.map(&:name).to_sentence}.\n"
    else
      message += ":crying_cat_face: There are unfortunatelly not more available parking spots.\n"
    end
    unless reservations.empty?
      message += "There are following reservations:\n"
      reservations.each do |reservation|
        message += " - Parking spot #{reservation.parking_spot.name} reserved by #{reservation.user.display_name}"
      end
    end

    client.say(text: message, channel: data.channel)
  end

  match /reserve\s?(?<date>.*)/i do |client, data, match|
    user = Bot.find_or_create_user(data.user, client)
    date = Bot.parse_user_date(match[:date])
    begin
      reservation = ReservationService.new.create_reservation(user.id, date, date)
      client.say(
          text: ":tada: I have reserved parking spot *#{reservation.parking_spot.name}* for you on: #{Bot.format_date(date)}. ",
          channel: data.channel
      )

    rescue ReservationService::NoAvailableParkingSpots
      client.say(
          text: ":crying_cat_face: Sorry, there are no available parking lots on #{Bot.format_date(date)}.",
          channel: data.channel
      )
    end
  end

  match /cancel\s?(?<date>.*)/i do |client, data, match|
    user = Bot.find_or_create_user(data.user, client)
    date = Bot.parse_user_date(match[:date])

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

  command 'ping' do |client, data, match|
    client.say(text: 'pong', channel: data.channel)
  end

  def self.find_or_create_user(slack_id, slack_client)
    User.find_or_create_by!(slack_id: slack_id) do |user|
      user.display_name = slack_client.web_client.users_info(user: slack_id)['user']['real_name']
    end
  end

  def self.parse_user_date(date_str)
    if date_str.present?
      Chronic.parse(date_str).to_date
    else
      1.day.from_now.to_date
    end
  end

  def self.format_date(date)
    date.strftime('%A, %B %-d, %Y')
  end
end
