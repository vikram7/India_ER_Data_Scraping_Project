require 'nokogiri'
require 'open-uri'
require 'pg'
require 'pry'

def db_connection
  begin
    connection = PG.connect(dbname: 'india_er_db')
    yield(connection)
  ensure
    connection.close
  end
end

def insert_into_db
end

array_of_ids = ['01AM014700', '01UL043600', '01AM015000']

  array_of_ids.each do |id|

  list = []

  url = "http://www.persmin.nic.in/ersheet/MultipleERS.asp?HiddenStr=#{id}"

  data = Nokogiri::HTML(open(url))

  for i in 1..22
    list << data.css('td')[i].text.strip if i % 2 == 0
  end

  sca = list[2].split('/')
  count = 2
  sca.each do |x|
    list.insert(count,x)
    count += 1
  end

  list.delete_at(5)

   sql = "INSERT INTO biodata (name, id, service, cadre, allotment_year, source_of_recruitment, date_of_birth, sex, place_of_domicile, mother_tongue, indian_languages, foreign_languages, retirement_reason) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)"
    db_connection do |db|
      db.exec(sql, list)
    end
  end


# #Complete Biodata (labels look to be constant across entries)
# for i in 0..22 do
#   p data.css('td')[i].text.strip if i % 2 == 0
#   print data.css('td')[i].text.strip if i % 2 == 1
# end

# #Details of Central Deputation (labels look to be constant across entries)
# i = 23
# while i <= 51
#   p data.css('td')[i].text.strip
#   i += 1
# end

# #Educational Qualifications (labels differ depending on number of educational qualifications)
# i = 52
# while i <= 64
#   p data.css('td')[i].text.strip
#   i += 1
# end
