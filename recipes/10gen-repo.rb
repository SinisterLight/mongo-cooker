template '/etc/yum.repos.d/10gen.repo' do
  source  '10gen.repo.erb'
  owner   'root'
  group   'root'
  mode    '0644'
end
