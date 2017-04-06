module TestCableguyAppCabling::Base
  class Blog < Palmade::Cableguy::Migration
    def migrate!
      group 'blog' do
        set 'fb_oauth', 'true'

        prefix 'mongo' do
          set 'host', '127.0.0.1'
          set 'port', '27019'
        end

        prefix 'db' do
          set 'host', '192.168.0.1'
          set 'port', '3307'
          set 'username', 'user'
          set 'password', ''
        end
      end
    end
  end
end
