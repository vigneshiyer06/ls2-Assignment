def get_command_line_argument
    # ARGV is an array that Ruby defines for us,
    # which contains all the arguments we passed to it
    # when invoking the script from the command line.
    # https://docs.ruby-lang.org/en/2.4.0/ARGF.html
    if ARGV.empty?
      puts "Usage: ruby lookup.rb <domain>"
      exit
    end
    ARGV.first
  end
  
  # `domain` contains the domain name we have to look up.
  domain = get_command_line_argument
  
  # File.readlines reads a file and returns an
  # array of string, where each element is a line
  # https://www.rubydoc.info/stdlib/core/IO:readlines
  dns_raw = File.readlines("zone")
  
  def parse_dns(dns_raw)
    a_records=dns_raw.map{|line| line.strip()}
    a_records=a_records.reject{|line| line.empty? || line[0]=="#"}
    a_records=a_records.map{|line| line.split(", ")}
    dns_records={}
    a_records.each do |new_record|
        abt_domain={:category => new_record[0], :alias => new_record[2]}
        dns_records[new_record[1]]=(abt_domain)
    end
    dns_records
end

def resolve(dns_records,lookup_chain,domain)
    if (dns_records[domain])
        
        if(dns_records[lookup_chain.last()][:category]=="A")
            lookup_chain.push(dns_records[lookup_chain.last()][:alias])
            return lookup_chain        
        else
            lookup_chain.push(dns_records[lookup_chain.last()][:alias])
            resolve(dns_records,lookup_chain,domain)
        end
    else
        puts "Error:could not find the respective IPv4 address for #{domain}"
        exit
        
    end
        
end            
  dns_records = parse_dns(dns_raw)
  lookup_chain = [domain]
  lookup_chain = resolve(dns_records, lookup_chain, domain)
  puts lookup_chain.join(" => ")
  
  