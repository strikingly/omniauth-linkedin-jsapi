require 'spec_helper'
require 'omniauth-linkedin-jsapi'

describe OmniAuth::Strategies::LinkedIn do

  # Initialize with fake api_key and secret_key
  subject {
    OmniAuth::Strategies::LinkedIn.new(nil, '67xrcd1q4dijzn', 'X19zkd7LdmSPVcrV')
  }

  it 'adds a camelization for itself' do
    expect(OmniAuth::Utils.camelize('linkedin')).to eq 'LinkedIn'
  end

  describe '#client' do
    it "creates an oauth consumer" do
      expect(subject.client.is_a?(OAuth::Consumer)).to be_true
    end
    it "has correct key" do
      expect(subject.client.key).to eq '67xrcd1q4dijzn'
    end
    it "has correct secret" do
      expect(subject.client.secret).to eq 'X19zkd7LdmSPVcrV'
    end
    it "has correct site" do
      expect(subject.client.site).to eq 'https://api.linkedin.com'
    end
  end

  describe '#validate_signature' do
    let(:payload) do
      {
        "signature_method"  => "HMAC-SHA1",
        "signature_order"   => ["access_token", "member_id"],
        "access_token"      => "AD2dpVe1tOclAsNYsCri4nOatfstw7ZnMzWP",
        "signature"         => "4pgJrTAD+EktW7c5VTuZFhLrmOA=",
        "member_id"         => "vvUNSej47H",
        "signature_version" => '1'
      }
    end

    it 'validates with correct signature' do
      expect(subject.validate_signature(payload)).to be_true
    end

    it 'fails to validate with signature version other than 1' do
      expect(subject.validate_signature(payload.merge("signature_version" => 2))).to be_false
    end

    it 'fails to validate with signature method other than HMAC-SHA1' do
      expect(subject.validate_signature(payload.merge("signature_method" => "HMAC-SHA256"))).to be_false
    end

    it 'fails to validate without signature_order' do
      expect(subject.validate_signature(payload.merge("signature_order" => nil))).to be_false
    end

    it 'fails to validate without unmatch signature' do
      expect(subject.validate_signature(payload.merge("signature" => "73f948524c6d1c07b5c554f6fc62d824eac68fee"))).to be_false
    end
  end

  describe '#user_name' do
    context 'when the user has first name and last name' do
      before { subject.stub(:raw_info => {'firstName' => 'Jim', 'lastName' => 'Green'}) }
      it 'returns the full name' do
        expect(subject.user_name).to eq 'Jim Green'
      end
    end
    context 'when the user only has first name' do
      before { subject.stub(:raw_info => {'firstName' => 'Jim'}) }
      it 'returns the first name' do
        expect(subject.user_name).to eq 'Jim'
      end
    end
    context 'when the user only has last name' do
      before { subject.stub(:raw_info => {'lastName' => 'Green'}) }
      it 'returns the last name' do
        expect(subject.user_name).to eq 'Green'
      end
    end
    context 'when the user does not have name' do
      before { subject.stub(:raw_info => {}) }
      it 'returns nil' do
        expect(subject.user_name).to be_nil
      end
    end
  end
end