node_array = ::File.open('./node_ip_results.txt').to_a

node_array.each do |n|
  shortname = n.split('.').first
  nodes.find("name:#{shortname}*").each do |hostname|
    puts hostname.run_list << 'role[ops_login]' unless hostname.run_list.include?('role[ops_login]')
    hostname.save
  end
end
