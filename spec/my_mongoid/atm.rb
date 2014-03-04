require "active_support"

class Account
  attr_reader :balance
  def initialize(balance)
    @balance = balance
  end

  def deposit(amount)
    @balance += amount
  end

  def withdraw(amount)
    @balance -= amount
  end

  def valid_access?
    true
  end
end

class ATM
  include ActiveSupport::Callbacks
  define_callbacks :command
  # todo around不起作用
  set_callback :command, :before do |object|
    log(object)
  end

  set_callback :command, :after do |object|
    log(object)
  end

  set_callback :command, :after do |object|
    send_sms(object)
  end

  attr_reader :account
  def initialize(account)
    @account = account
  end
end

module ATM::Commands

  def withdraw(amount)
    run_callbacks :command do
      account.withdraw(amount)
      -amount
    end
  end

  def deposit(amount)
    run_callbacks :command do
      account.deposit(amount) if valid_access?
      amount
    end
  end
end

module ATM::Authentication
  extend ActiveSupport::Concern

  def valid_access?
    @account.valid_access?
  end
end

module ATM::Logging
  extend ActiveSupport::Concern

  def log(msg)
    puts msg
  end
end

module ATM::SMSNotification
  extend ActiveSupport::Concern

  def send_sms(msg)
    # fake send
  end
end

module ATM::Concerns
  extend ActiveSupport::Concern

  included do
    include ActiveSupport::Callbacks
    include ATM::Commands
    include ATM::Authentication
    include ATM::Logging
    include ATM::SMSNotification
  end
end

ATM.include ATM::Concerns
