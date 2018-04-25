# # encoding: utf-8

# Inspec test for recipe gate-install::default


unless os.windows?
  describe user('root'), :skip do
    it { should exist }
  end
  describe user('gate_sso'), :skip do
    it { should exist }
  end
  describe group('gate_sso'), :skip do
    it { should exist }
  end
end

# This is an example test, replace it with your own test.
describe port(80), :skip do
  it { should_not be_listening }
end

describe package('ruby2.4') do
  it { should be_installed }
end

describe package('nodejs') do
  it { should be_installed}
end

describe gem('bundler') do
  it { should be_installed }
end

control 'ruby' do
  impact 1.0
  title 'Check right ruby version'
  desc 'Check that ruby 2.4 is installed and  is available.'
  describe command("ruby -v") do
    its('stdout.strip') { should cmp == "ruby 2.4.3p205 (2017-12-14 revision 61247) [x86_64-linux-gnu]" }
    its('exit_status') { should eq 0 }
  end
end
