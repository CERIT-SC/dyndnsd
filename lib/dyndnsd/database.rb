
require 'forwardable'
require 'tempfile'

module Dyndnsd
  class Database
    extend Forwardable
    
    def_delegators :@db, :[], :[]=, :each, :has_key?
  
    def initialize(db_file)
      @db_file = db_file
    end
    
    def load
      if File.file?(@db_file)
        @db = JSON.load(File.open(@db_file, 'r') { |f| f.read })
      else
        @db = {}
      end
      @db_hash = @db.hash
    end
    
    def save
      f = Tempfile.new(File.basename(@db_file+'.'), File.dirname(@db_file))

      begin
        JSON.dump(@db, f)
        f.close
        File.rename(f.path, @db_file)

        @db_hash = @db.hash
      rescue
        f.close!
        raise
      end
    end
    
    def changed?
      @db_hash != @db.hash
    end
  end
end
