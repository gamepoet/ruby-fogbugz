require 'cgi'
require 'net/https'
require 'net/http/post/multipart'

module Fogbugz
  module Adapter
    module HTTP
      class NetHttp
        attr_accessor :root_url, :requester

        def initialize(options = {})
          @root_url = options[:uri]
        end

        def request(action, options)
          uri = URI("#{@root_url}/api.asp")

          params = {
            'cmd' => action
          }
          params.merge!(options[:params])

          # add attachments
          if !options[:attachments].empty?
            params[:nFileCount] = options[:attachments].size
            options[:attachments].each_with_index do |attachment, index|
              params["File#{index + 1}"] = UploadIO.new(
                attachment[:file],
                attachment[:content_type] || 'application/octet-stream',
                attachment[:filename]
                )
            end
          end

          # build up the form request
          request = Net::HTTP::Post::Multipart.new(uri, params)

          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = @root_url.start_with? 'https'
          
          response = http.start {|http| http.request(request) }
          response.body
        end
      end
    end
  end
end
