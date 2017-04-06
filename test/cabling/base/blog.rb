module TestCableguyCabling::Base
  class Blog < Palmade::Cableguy::Migration
    def migrate!
      group 'blog' do
        set 'require_2fa', 'true'
        set 'twitter_auth', 'true'

        prefix 'db' do
          set 'host', '127.0.0.1'
          set 'port', '3306'
          set 'username', 'root'
          set 'password', ''
        end
      end
    end
  end
end
