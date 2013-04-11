require 'aws-sdk'
require 'rest-client'

class Chef::DataBagHelper

  def initialize
    @bucket = @node[:aws][:key_bucket]

    AWS.config(access_key_id: @node[:aws][:access_key],
               secret_access_key: @node[:aws][:secret_key])
  end

  def s3
    @s3 ||= AWS::S3.new
  end

  def generate_s3_url(path)
    s3.buckets[@bucket].objects[path].url_for(:read, expires: Time.now + 600).to_s
  end

  def pass(key="default_key")
    RestClient.get(generate_s3_url(key)).body.strip
  end

  def load_encrypted_bag(bag, key, secret="default_key")
    Chef::EncryptedDataBagItem.load(bag, key, pass(secret))
  end
end
