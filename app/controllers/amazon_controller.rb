require 'base64'
require 'openssl'

class AmazonController < ApplicationController
  ACCESS_KEY = 'XXXXXXXXXXXXXXXXXXXX'
  SECRET_KEY = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
  
  def index
    generate_signed_form(ACCESS_KEY, SECRET_KEY, 
          'amount' => 'USD 10.99', 
          'description' => 'Pay for using http://amityadav.name Services', 
          'referenceId' => 'txn1101', 
          'returnUrl' => 'http://localhost:3005/amazon/amazon_complete',
          'abandonUrl' => 'http://localhost:3005/amazon')
  end
  
  def generate_signed_form(access_key, aws_secret_key, form_params)
    form_params['accessKey'] = access_key
    
    # lexicographically sort the form parameters
    # and create the canonicalized string
    str_to_sign = ""
    form_params.keys.sort.each { |k| str_to_sign += "#{k}#{form_params[k]}" }
  
    # calculate signature of the above string
    digest = OpenSSL::Digest::Digest.new('sha1')
    hmac = OpenSSL::HMAC.digest(digest, aws_secret_key, str_to_sign)
    form_params['signature'] = Base64.encode64(hmac).chomp
  
    # construct the form
    @signed_form =<<-STARTFORM
                      <form action="https://authorize.payments-sandbox.amazon.com/pba/paypipeline" method="post">
                  STARTFORM
  
    form_params.each do |key, value|
      next unless key and value
      @signed_form +=<<-"FORMELEM"
        <input type="hidden" name="#{key}" value="#{value}" >
        FORMELEM
    end
  
    @signed_form +=<<-ENDFORM
        <input type="image" src="https://authorize.payments-sandbox.amazon.com/pba/images/amazonPaymentsButton.jpg" border="0" >
    </form>
      ENDFORM
  end


  def amazon_complete
    
  end

end
