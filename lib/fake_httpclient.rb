# FakeWeb - Ruby Helper for Faking Web Requests
# Copyright 2006 Blaine Cook <romeda@gmail.com>.
# 
# FakeWeb is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# FakeWeb is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with FakeWeb; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

require 'rubygems'
gem 'httpclient', '>=2.1.2'
require 'httpclient'

class HTTPClient

  LIBRARY_IDENTIFIER = :httpclient
  FakeWeb.register_client_library(LIBRARY_IDENTIFIER)

  alias :original_httpclient_do_get_block :do_get_block

  def self.socket_type
    FakeWeb::SocketDelegator
  end
  
  def do_get_block(req, proxy, conn, &block)
    uri = req.header.request_uri
    canonical_uri = "#{uri.scheme}://#{uri.host}#{uri.path}"
    if FakeWeb.registered_uri?(canonical_uri)
      message = FakeWeb.response_for(LIBRARY_IDENTIFIER, canonical_uri, &block)
      conn.push(message)
    else
      original_httpclient_do_get_block(req, proxy, conn, &block)
    end
  end

=begin
  # Do we want this? I'd imagine it'd make unregistered urls unhappy...

  # Make sure there's no chance of a connection being made
  class Session
    def query(req)
    end
  end
=end

end

# A uniform way to get fake content, for testing.
module HTTP
  class Message
    def get_content
      self.body.content
    end
  end
end
