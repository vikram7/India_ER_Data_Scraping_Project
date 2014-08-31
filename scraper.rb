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


array_of_ids = ['01AM014700', '01UL043600', '01AM015000']

array_of_ids.each do |id|
  start_time = Time.new

  biodata_list = []
  details_of_central_deputation_list = []

  url = "http://www.persmin.nic.in/ersheet/MultipleERS.asp?HiddenStr=#{id}"

  data = Nokogiri::HTML(open(url))

  #this section inserts the biodata from the page into the database table 'biodata'
  for i in 1..22
    biodata_list << data.css('td')[i].text.strip if i % 2 == 0
  end

  sca = biodata_list[2].split('/')
  count = 2
  sca.each do |x|
    biodata_list.insert(count,x)
    count += 1
  end

  biodata_list.delete_at(5)

   sql = "INSERT INTO biodata (name, id, service, cadre, allotment_year, source_of_recruitment, date_of_birth, sex, place_of_domicile, mother_tongue, indian_languages, foreign_languages, retirement_reason) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)"
    db_connection do |db|
      db.exec(sql, biodata_list)
    end

    #this section inserts the Details of Central Deputation into the database table 'details_of_central_deputation'

  i = 27
  while i <= 51
    details_of_central_deputation_list << data.css('td')[i].text.strip.to_s
    i += 4
  end

  details_of_central_deputation_list.insert(0, biodata_list[1])
  sql = "INSERT INTO details_of_central_deputation (id, whether_presently_on_deputation_to_goi, date_of_start_of_central_deputation, expiry_date_of_tenure_of_central_deputation, tenure_code, if_in_cadre_date_of_reversion, whether_debarred_from_central_deputation, if_so_period_of_debarment) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)"
  db_connection do |db|
    db.exec(sql, details_of_central_deputation_list)
  end

  puts "ID# " + id.to_s + " took " + (Time.now - start_time).to_s + " seconds to scrape and insert into the database"
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
