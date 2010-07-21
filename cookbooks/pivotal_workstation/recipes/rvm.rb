include_recipe "pivotal_workstation::bash_profile"

rvm_git_revision_hash  = version_string_for("rvm")

::RVM_HOME = "#{WS_HOME}/.rvm"
::RVM_COMMAND = "#{::RVM_HOME}/bin/rvm"

run_unless_marker_file_exists(marker_version_string_for("rvm")) do
  recursive_directories [RVM_HOME, 'src', 'rvm'] do
    owner WS_USER
    recursive true
  end

  execute "download rvm" do
    command "curl -Lsf http://github.com/wayneeseguin/rvm/tarball/#{rvm_git_revision_hash} | tar xvz -C#{RVM_HOME}/src/rvm --strip 1"
    user WS_USER
  end
  
  execute "install rvm" do
    cwd "#{RVM_HOME}/src/rvm"
    command "./install"
    user WS_USER
  end
  
  template "#{BASH_INCLUDES_SUBDIR}/rvm" do
    source "bash_profile_rvm.erb"
    owner WS_USER
  end
  
  execute "check rvm" do
    command "#{RVM_COMMAND} --version | grep Wayne"
    user WS_USER
  end
  
  execute "HACK the rvm openssl install script.  ./Configure was failing with 'target already defined'.  we've filed a bug about this" do
    command "perl -pi -e 's/os\\/compiler darwin/darwin/g' #{::RVM_HOME}/scripts/package"
  end
  
  
  %w{readline autoconf openssl zlib}.each do |rvm_package|
    execute "install rvm package: #{rvm_package}" do
      command "#{::RVM_COMMAND} package install #{rvm_package}"
      user WS_USER
    end
  end
end

node["rvm"]["rubies"].each do |ruby_version_string|
  rvm_ruby_install(ruby_version_string)
end