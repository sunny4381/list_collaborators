require 'octokit'
require 'io/console'

print "OTP CODE: "
@otp_code = STDIN.noecho(&:gets).chomp
print "\n"

@client = Octokit::Client.new(netrc: true)
@client.auto_paginate = true

def each_organization_repository(organization, &block)
  @client.organization_repositories(organization, headers: { "X-GitHub-OTP" => @otp_code }).each(&block)
end

each_organization_repository(ARGV[0]) do |repository|
  puts repository.full_name

  @client.collaborators(repository.full_name, headers: { "X-GitHub-OTP" => @otp_code }).each do |collab|
    permissions = []
    permissions << "pull" if collab.permissions.pull
    permissions << "push" if collab.permissions.push
    permissions << "admin" if collab.permissions.admin
    puts "-- " + collab.login + "(" + permissions.join(",") + ")"
  end
end
