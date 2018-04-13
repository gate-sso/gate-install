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

describe gem('bundler', 'bundle') do
  it { should be_installed }
end

describe file('/tmp/gate_source.zip') do
  it {should exist}
end

describe file('/opt/gate_sso/gate_release.tar.gz') do
  it {should exist}
end

describe directory('/opt/gate_sso/gate-master') do
  it {should exist}
end
