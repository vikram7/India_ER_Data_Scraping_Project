require 'nokogiri'
require 'open-uri'

url = "http://www.persmin.nic.in/ersheet/MultipleERS.asp?HiddenStr=01UL043600"

data = Nokogiri::HTML(open(url))

# puts data.at_css("#Left2").text.strip
# puts data.at_css("#Right").text.strip

p "Complete Biodata"
p data.css('td')[0].text.strip
p data.css('td')[1].text.strip
p data.css('td')[2].text.strip
p data.css('td')[3].text.strip
p data.css('td')[4].text.strip

