require 'open-uri'
require 'json'
require 'uri'
require 'colorize'
require 'artii'
require 'fileutils'
require 'net/http'

def banner
  a = Artii::Base.new :font => 'smslant'
  banner_text = a.asciify("RubyRedditParser").chomp.split("\n")

  banner_width = banner_text[0].length

  max_line_length = banner_text.map(&:length).max

  banner_text.each do |line|
    centered_line = line.center(max_line_length)
    centered_line.each_char do |char|
      print char.colorize(:mode => :bold, :color => :black, :background => :yellow)
    end
    puts ""
  end
end

def send_to_telegram(token, chat_id, message)
  uri = URI("https://api.telegram.org/bot#{token}/sendMessage")
  res = Net::HTTP.post_form(uri, 'chat_id' => chat_id, 'text' => message)
  unless res.is_a?(Net::HTTPSuccess)
    puts "❌ Error sending message to Telegram: #{res.body}".red.on_light_black
  end
end

subreddit = ARGV[0]
download_content = ARGV.include?("-d")
send_to_telegram_flag = ARGV.include?("-t")
extensions_count = Hash.new(0)

if subreddit.nil?
  banner
  puts ""
  print "Enter subreddit name:".green.on_light_black
  subreddit = gets.chomp
end

some_url = "https://www.reddit.com/r/#{subreddit}/.json?limit=50000"
direct_links = []
after_param = nil

loop do
  url_with_after = after_param ? "#{some_url}&after=#{after_param}" : some_url
  json_string = URI.open(url_with_after, 'User-Agent' => 'dl-script').read
  the_data = JSON.parse(json_string)
  some_data = the_data['data']['children']

  some_data.each do |x|
    some_value = nil

    if x['data']['media'] && x['data']['media'].key?('reddit_video_preview')
      some_value = x['data']['media']['reddit_video_preview']['fallback_url']
    elsif x['data']['preview'] && x['data']['preview'].key?('reddit_video_preview')
      some_value = x['data']['preview']['reddit_video_preview']['fallback_url']
    else
      some_value = x['data']['url_overridden_by_dest'] || x['data']['url']
    end

    if some_value.match(/\.(mp4|jpeg|gif|jpg|m4s|png)$/i)
      extension = File.extname(some_value).gsub('.', '').downcase
      extensions_count[extension] += 1
      unless direct_links.include?(some_value)
        direct_links << some_value
      end
    end
  end

  unique_links_count = direct_links.size
  extensions_summary = extensions_count.map { |ext, count| "(#{ext}: #{count})" }.join(' ')

  puts "🌟 Found #{unique_links_count} unique links ".green.on_light_black +
       "#{extensions_summary}".yellow.on_light_black

  after_param = the_data['data']['after']

  break if after_param.nil?

  sleep 1
end

if download_content

  folder_name = subreddit.downcase

  unless File.directory?(folder_name)
    FileUtils.mkdir_p(folder_name)
    puts "📂 Created folder: #{folder_name}".light_blue.on_light_black
  end

  direct_links.each_with_index do |link, index|
    begin
      file_name = File.basename(URI.parse(link).path)
      file_path = "#{folder_name}/#{file_name}"
      URI.open(link) do |url|
        File.open(file_path, 'wb') do |file|
          file.write(url.read)
          puts "📥 Downloaded #{file_name} (#{index + 1}/#{direct_links.size})".magenta.on_light_black
        end
      end
    rescue => e
      puts "❌ Error downloading #{link}: #{e.message}".red.on_light_black
    end
  end
else
  File.open("#{subreddit}_links.txt", "a") do |file|
    direct_links.each do |link|
      file.puts link
    end
  end

  puts "🎉 Done. No more new links found.".green.on_light_black
end

if send_to_telegram_flag
  print "Enter Telegram Bot Token:".green.on_light_black
  token = gets.chomp
  print "Enter Telegram Chat ID:".green.on_light_black
  chat_id = gets.chomp

  message = "Links from subreddit #{subreddit}:\n" + direct_links.join("\n")
  send_to_telegram(token, chat_id, message)
  puts "📤 Sent links to Telegram.".green.on_light_black
end
