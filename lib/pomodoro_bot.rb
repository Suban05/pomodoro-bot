require 'telegram/bot'
require 'dotenv/load'

class PomodoroBot
  def initialize
    @timers = {}
  end

  def start
    Telegram::Bot::Client.run(ENV['TELEGRAM_BOT_TOKEN']) do |bot|
      bot.listen do |message|
        Thread.new { process_message(bot, message) }
      end
    end
  end

  private

  def process_message(bot, message)
    chat_id = message.chat.id

    case message.text
    when '/start'
      bot.api.send_message(
        chat_id: chat_id,
        text: 'Hello. My name is PomodoroBot. I use pomodoro method by Francesco Cirillo and I ready to help upgrade your effectiveness. Press /start_task that start timer.'
      )
    when commands.first
      start_task(bot, chat_id)
    when commands.last
      stop_task(bot, chat_id)
    else
      other_command(bot, message.chat.id)
    end
  end

  def start_task(bot, chat_id)
    if @timers[chat_id]
      bot.api.send_message(chat_id: chat_id, text: 'Task is already exists.')
      return
    end

    @timers[chat_id] = PomodoroTimer.new(bot, chat_id)
    @timers[chat_id].start
  end

  def stop_task(bot, chat_id)
    if @timers[chat_id]
      @timers[chat_id].stop
      @timers.delete(chat_id)
      bot.api.send_message(chat_id: chat_id, text: 'Task stopped.')
    else
      bot.api.send_message(chat_id: chat_id, text: 'No active tasks to interrupt.')
    end
  end

  def other_command(bot, chat_id)
    bot.api.send_message(
      chat_id: chat_id,
      text:
        "Unknown command. Please, use #{commands.join(', ')} to work with me."
    )
  end

  def commands
    %w[/start_task /stop_task]
  end
end
