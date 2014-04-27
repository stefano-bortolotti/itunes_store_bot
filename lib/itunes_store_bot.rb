require 'net/http'
require 'openssl'
require 'json'

class AppStoreBot

  def initialize(app_id, app_country='gb')
    @app_id = app_id
    @app_country = app_country

    @itunes_domain_url = 'itunes.apple.com'
    @itunes_http_options = {'User-Agent' => 'iTunes/11.1.5 (Macintosh; OS X 10.9.2) AppleWebKit/537.74.9'}
    @itunes_reviews_url = ''

    @app_data = {}
    get_app_info
  end

  def get_app_data
    @app_data
  end

  def update_app_data
    get_app_info
    @app_data
  end

  def get_app_rating
    @app_data['all_versions'][:ratingAverage]
  end

  def get_app_voters_count
    @app_data['all_versions'][:ratingCount]
  end

  def get_last_app_rating
    @app_data['last_version'][:ratingAverage]
  end

  def get_last_app_voters_count
    @app_data['last_version'][:ratingCount]
  end

  def get_last_version_reviews(sort_type='4') # 1: , 2: , 3: , 4: most recent
    get_reviews('last_version', sort_type)
    @app_data['last_version'][:reviews]
  end

  def get_all_versions_reviews(sort_type='4') # 1: , 2: , 3: , 4: most recent
    get_reviews('all_versions', sort_type)
    @app_data['all_versions'][:reviews]
  end

  private 

  def get_app_info

    # https://itunes.apple.com/gb/customer-reviews/id576939960?dataOnly=true&displayable-kind=11&appVersion=current
    http = Net::HTTP.new(@itunes_domain_url, Net::HTTP.https_default_port())
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # disable ssl certificate check

    path = "/#{@app_country}/customer-reviews/id#{@app_id}?dataOnly=true&displayable-kind=11"
    # request the current app json data
    response = http.request( Net::HTTP::Get.new( path + "&appVersion=current" , @itunes_http_options) )

    if response.code != '200'
      puts "App Store store website communication (status-code: #{response.code})\n#{response.body}"
    else
      @app_data['last_version'] = extract_app_data_from_raw_json( response.body )
      #puts "#{@app_data['last_version']}"
    end

    # request the app all versions json data
    response2 = http.request( Net::HTTP::Get.new( path , @itunes_http_options) )

    if response2.code != '200'
      puts "App Store store website communication (status-code: #{response2.code})\n#{response2.body}"
    else
      @app_data['all_versions'] = extract_app_data_from_raw_json( response2.body )
      #puts "#{@app_data['all_versions']}"
    end

  end

  def extract_app_data_from_raw_json(data)
    raw_app_data = JSON.parse( data )
    set_itunes_review_url_path( raw_app_data['userReviewsRowUrl'] )
    parsed_app_data = {
      :ratingCount => raw_app_data['ratingCount'] || 0,
      :ratingAverage => raw_app_data['ratingAverage'] || 0.0,
      :ratingCountList => raw_app_data['ratingCountList'] || [0, 0, 0, 0, 0],
      :numberOfReviews => raw_app_data['totalNumberOfReviews'] || 0,
      :reviews => []
    }
  end

  def set_itunes_review_url_path(url)
    index = url.index(@itunes_domain_url)
    @itunes_reviews_url = url[index, url.length].gsub! @itunes_domain_url, ""
  end

  def get_reviews(version='last_version', sort_type='1')

    # https://itunes.apple.com/WebObjects/MZStore.woa/wa/userReviewsRow?cc=gb&id=576939960&displayable-kind=11&startIndex=0&endIndex=8&sort=1&appVersion=current
    http = Net::HTTP.new(@itunes_domain_url, Net::HTTP.https_default_port())
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # disable ssl certificate check

    query_parameters = "?cc=#{@app_country}&id=#{@app_id}&displayable-kind=11&startIndex=0&endIndex=9&sort=#{sort_type}"
    query_parameters += "&appVersion=current" if ( version == 'last_version' )
    path = @itunes_reviews_url + query_parameters
    #puts path

    # request the app json data
    response = http.request( Net::HTTP::Get.new( path + query_parameters, @itunes_http_options) )

    if response.code != '200'
      puts "App Store store communication (status-code: #{response.code})\n#{response.body}"
    else
      #print "#{response.body}\n"
      reviews = JSON.parse( response.body )
      parsed_reviews = []

      reviews['userReviewList'].each do |review|
        #print "#{review}\n"
        parsed_reviews.push( { 
            :title => review['title'],
            :vote => review['rating'],
            :body => review['body'],
            :date => review['date'],
            :name => review['name'],
            :id => review['userReviewId']
          } )
      end
      @app_data[version][:reviews] = parsed_reviews
    end
  end

end

#a = AppStoreBot.new('457876088', 'us') # minigore 576939960; ASOS 457876088
#puts "Last App Rating #{a.get_last_app_rating}"
#puts "Last App Voters count #{a.get_last_app_voters_count}"
#puts "All time App Rating #{a.get_app_rating}"
#puts "All time App Voters count #{a.get_app_voters_count}"
#puts "#{a.get_last_version_reviews('4')}"
#puts a.get_app_data

