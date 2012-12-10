require 'optparse'
require 'prover'
require 'verifier'

opts = {}

opt_parser = OptionParser.new do |opt|
  opt.banner = "Usage: opt_parser COMMAND [OPTIONS]"
  opt.separator  ""
  opt.separator  "Commands"
  opt.separator  "     start: start server"
  opt.separator  "     stop: stop server"
  opt.separator  "     restart: restart server"
  opt.separator  ""
  opt.separator  "Options"

  opt.on("-k","--security-parameter PARAM", Numeric, "which environment you want server run") do |k|
    opts[:k] = k
  end

  opt.on("-n","--stream-size SIZE", Numeric, "Upper bound on length of stream") do |n|
    opts[:n] = n
  end

  opt.on("-m","--universe-size SIZE", Numeric, "Size of universe of elements") do |m|
    opts[:m] = m
  end

  opt.on("-t", "--test", "Run in test mode.") do
  	opts[:test] = true
  end



  opt.on("-h","--help","help") do
    puts opt_parser
  end

end

opt_parser.parse!

p = Prover.new(opts[:k], opts[:n], opts[:m], opts[:test])
v = Verifier.new(p.k, p.stream_bound_n, p.q, p.log_q_ceil, p.L, p.R, p.universe_size_m)


command = "help"

while command != "quit"
	case command
	when "add"
		print "Add element (0 ... #{p.universe_size_m - 1} ): "
		

		begin
			element = gets.chomp.to_i

			puts "Adding #{element}"
			p.addElement( element )
			v.update_root_digest( element )

			puts "Prover leaves: #{p.leaves}"
			puts "Verifier digest: #{v.root_digest}"	
		rescue => err
			puts "Something went wrong"
			puts err
		end

		

	when "query"
		print "Membership query (Enter binary index using #{p.bits_needed_for_leaves} bits): "

		begin

			target = gets.chomp

			puts "Query requested for: #{target}"

			# TODO - Membership proof expects an index (make a public interface to expect an integer)

			proof = p.get_membership_proof(target)
			valid = v.verify_membership_proof proof

			puts "Prover provided valid proof? : #{valid}"
		rescue => err
			puts "Something went wrong"
			puts err
		end

	when "help"
		puts "Choose: (add) Element, (query), (help), (quit)"
	else
		puts "Invalid selection"
	end
		
	print "Choose: (add) Element, (query), (help), (quit): "
	command = gets.chomp
		
end