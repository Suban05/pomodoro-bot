class PomodoroTimer
  def initialize(bot, chat_id)
    @bot = bot
    @chat_id = chat_id
    @task_time = 25
    @interval = to_minutes(@task_time)
    @pomodoro_count = 0
    @active = true
    @tread = nil
  end

  def start
    send_message("The task has been running for #{@task_time} minutes.")

    @tread = Thread.new do
      sleep(@interval)

      if active?
        @pomodoro_count += 1

        if @pomodoro_count <= 4
          inspect_pomodoro_count = 5 - @pomodoro_count
          send_message_and_sleep("The time of 25 minutes has expired. Rest time is 5 minutes. Tomatoes left: #{inspect_pomodoro_count}.", to_minutes(5))
          start
        else
          send_message_and_sleep('Break for 15 minutes.', to_minutes(15))
          reset_pomodoro_count
          start
        end
      end
    end
  end

  def stop
    @active = false
    if @tread
      @tread.kill
    end
  end

  private

  def active?
    @active
  end

  def reset_pomodoro_count
    @pomodoro_count = 0
  end

  def send_message_and_sleep(message, duration)
    send_message(message)
    sleep(duration)
  end

  def send_message(text)
    @bot.api.send_message(chat_id: @chat_id, text: text)
  end

  def to_minutes(s)
    s * 60
  end
end
