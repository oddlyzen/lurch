require 'slimtimer4r'

class Controller < Autumn::Leaf
  @@TASKS=[]
  @@INTERRUPTIONS=[]
  
  def task_command(stem, sender, reply_to, msg)
    #init_slim_timer
    task = Timing::Task.new(:user => sender, :description => msg)
    var :msg => msg
    var :id => task.id
    var :user => get_nick(sender)
    @@TASKS << task
  end
  
  def tasks_command(stem, sender, reply_to, msg)
    @@TASKS.each do |t|
      if t.user == sender
        stem.message "<ID:#{t.id}> '#{t.description}' (#{t.total_time == 0 ? t.time_elapsed : t.total_time + t.time_elapsed} seconds) #{('| Tagged: ' + t.tags.join(", ") + '.') unless t.tags.nil? || t.tags.empty?}"
      end
    end    
  end
  
  def interrupt_command(stem, sender, reply_to, msg)
    if msg.nil?
      var :command_prefix => command_prefix
      render :interrupt_help
    else
      id = msg.sub!(/(\d){9}/) do |m|
        m[0].to_i
      end
      msg = msg.strip! 
      if id.nil?
        tasks = []
        @@TASKS.each do |t|
          if t.user == sender
            t.pause! "Interrupted! '#{msg}'"
            rupt = Timing::Interruption.new(:user => sender, :description => msg)
          end
        end
        tasks << t
        @@INTERRUPTIONS << rupt
      else
        tasks = []
        @@TASKS.each do |t|
          if t.user == sender && t.id == id
            t.pause! "Interrupted! '#{msg}'"
            rupt = Timing::Interruption.new(:user => sender, :description => msg)
          end
          tasks << t
          @@INTERRUPTIONS << rupt
        end
        var :tasks => tasks
        var :msg => msg
      end
    end
  end
  
  def resume_command(stem, sender, reply_to, msg)
    @@INTERRUPTIONS.each do |i|
      if i.user == sender
        i.end! "RESUMING TASK (#{msg})"
      end
    end
    tasks = []
    @@TASKS.each do |t|
      if t.user == sender
        t.resume! "#{msg}" if t.paused?
        tasks << t
      end
    end
    var :tasks => tasks
    var :msg => msg
  end
  
  def end_command(stem, sender, reply_to, msg)
    records = []
    if msg.nil?
      var :command_prefix => command_prefix
      render :end_help and return
    else
      args = msg.split(" ")
      if args[0].downcase == 'all'
        records = end_all(sender, msg)
      else
        id  = args[0].to_i
        all_tasks = @@INTERRUPTIONS + @@TASKS
        all_tasks.each do |t|
          if t.user == sender && t.id == id
            stem.message "Found object <#{t.id}>..."
            t.end! "#{args[1]}"
            @@INTERRUPTIONS.delete t
            @@TASKS.delete t
          end
        end
      end
      var :records => records
      begin
        synchronize_with_server(records)
        stem.message "Synchronized to SlimTimer API."
      rescue
        var :exception => "An error occurred: (#{$!.to_s})"
      end
    end
  end
  
  def tag_command(stem, sender, reply_to, msg)
    if msg.nil?
      var :command_prefix => command_prefix
      render :tag_help
    else
      var :success => false
      args = msg.split(" ")
      id   = args[0].to_i
      tags = args[1].split(',')
      records = @@TASKS + @@INTERRUPTIONS
      records.each do |t|
        if t.id == id
          stem.message "Found object <#{id}>:"
          var :success => true
          tags.each do |tag|
            t.tag! tag
          end
        end
      end
      var :tags => tags.join(',')
    end
  end
  
  # Look up acronyms and man pages. (@nsussman)
  def wtf_command(stem, sender, reply_to, msg)
    %x{wtf #{msg}}
  end
  
  def about_command(stem, sender, reply_to, msg)
    "#{ options[:about_msg].nil? ? 'Lurch (c) 2009, Zepfrog. (An Autumn Leaf)' : options[:about_msg] }"
  end
  
  private
  
  def init_slim_timer
    @timer = SlimTimer.new(options[:st_user], options[:st_password], options[:st_api_key])
  end
  
  def synchronize_with_server(records)
    init_slim_timer
    task = nil
    records.each do |r|
      task = @timer.create_task r.description, r.tags
      @timer.create_timeentry r.created_at, r.total_time, task['id'], r.ended_at
    end
  end
  
  def command_prefix
    options[:command_prefix]
  end
  
  def end_all(sender, msg)
    records = []
    @@INTERRUPTIONS.each do |i|
      if i.user == sender
        i.end! "#{msg}"
        records << i unless records.include? i
        @@INTERRUPTIONS.delete i
      end
    end
    @@TASKS.each do |t|
      if t.user == sender
        records << t unless records.include? t
        t.end! "#{msg}"
        @@TASKS.delete t
      end
    end
    records
  end
  
  def get_nick(sender)
    sender.to_a[2].to_s.gsub!(/(^nick)/, '')
  end
  
end


module Timing
  class Task < Object
    attr_accessor :user, :description, :total_time, :created_at, :ended_at, :started_at, :paused_at, :pause_time, :tags
    def initialize(args={})
      @created_at = Time.new
      @started_at = Time.new
      @user = args[:user]
      @description = args[:description]
      @tags = args[:tags]
      @coworker_emails = args[:coworker_emails] || nil
      @reporter_emails = args[:reporter_emails] || nil
      @ended_at = nil
      @paused_at = nil
      @total_time = 0
      @pause_time = 0
      @tags = []
    end
    
    def pause!(reason)
      @total_time += (Time.new - @started_at)
      @paused_at = Time.new
    end
    
    def paused?
      return true unless @paused_at.nil? 
      false
    end
    
    def end!(reason)
      @ended_at = Time.new
      @total_time += @ended_at - @started_at
    end
    
    def resume!(msg)
      if paused?
        @pause_time += (Time.new - @paused_at)
        @paused_at = nil
        @started_at = Time.new
        @ended_at = nil
      end
    end
    
    def tag!(tag)
      @tags << tag
    end
    
    def current_time
      Time.new
    end
    
    def time_elapsed
      if @ended_at.nil?
        if @paused_at.nil?
          current_time - @started_at 
        else
          @paused_at - @started_at
        end
      else 
        @ended_at - @started_at
      end
    end
    
    def coworker_emails
      @coworker_emails || []
    end
    
    def reporter_emails
      @reporter_emails || []
    end
    
    def coworker_emails=(array)
      @coworker_emails = array
    end
    
    def reporter_emails=(array)
      @reporter_emails = array
    end
  end
  
  class Interruption < Task
    def inititalize(args={})
      super
    end
    def tags
      @tags.include?('interruption') ? @tags : @tags << 'interruption'
    end
  end
  
end
