#
# Cookbook Name:: kafka
# Recipe:: default
#

include_recipe 'java'

user      = node[:kafka][:user]
group     = node[:kafka][:group]

broker_id = node[:kafka][:broker_id]
host_name = node[:kafka][:host_name]

group(group) {}

user(user) do
  comment 'User for Kafka'
  gid group
  home "/home/#{user}"
  shell '/bin/false'
  supports(:manage_home => false)
end

install_dir = node[:kafka][:install_dir]

directory install_dir do
  owner user
  group group
  mode '755'
  recursive true
  action :create
  not_if { File.directory?("#{install_dir}") }
end

directory "#{install_dir}/bin" do
  owner user
  group group
  mode '755'
  recursive true
  action :create
  not_if { File.directory?("#{install_dir}/bin") }
end

directory "#{install_dir}/config" do
  owner user
  group group
  mode '755'
  recursive true
  action :create
  not_if { File.directory?("#{install_dir}/config") }
end

directory("#{node[:kafka][:install_dir]}/libs") do
  owner user
  group group
  mode '755'
  action :create
  recursive true
  not_if { File.exists?("#{node[:kafka][:install_dir]}/libs") }
end

directory node[:kafka][:log_dir] do
  owner   user
  group   group
  mode    '755'
  recursive true
  action :create
  not_if { File.directory?(node[:kafka][:log_dir]) }
end

directory node[:kafka][:data_dir] do
  owner   user
  group   group
  mode    '755'
  recursive true
  action :create
  not_if { File.directory?(node[:kafka][:data_dir]) }
end

template '/etc/init.d/kafka' do
  source 'initd.script.erb'
  owner 'root'
  group 'root'
  mode '755'
  variables({
    :daemon_name => 'kafka',
    :main_class => 'kafka.Kafka',
    :jmx_port => node[:kafka][:jmx_port],
    :log4j_config => node[:kafka][:log4j_config],
    :config => node[:kafka][:config]
  })
end

include_recipe 'kafka::config'

service 'kafka' do
  supports :start => true, :stop => true, :restart => true
  action [:enable]
end
