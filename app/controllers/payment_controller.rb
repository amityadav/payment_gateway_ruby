require "money"
class PaymentController < ApplicationController
  include ActiveMerchant::Billing
  include ActiveMerchant::Billing::Integrations

  def index
    
  end
  
  #---------------Paypal Express Checkout------------------------------
  
  def paypal_express
    
  end

  def checkout
    setup_response = gateway.setup_purchase(5000,
      :ip                => request.remote_ip,
      :return_url        => url_for(:action => 'confirm', :only_path => false),
      :cancel_return_url => url_for(:action => 'index', :only_path => false)
    )
    redirect_to gateway.redirect_url_for(setup_response.token)
  end

  def confirm
    redirect_to :action => 'index' unless params[:token]
    
    details_response = gateway.details_for(params[:token])
    
    if !details_response.success?
      @message = details_response.message
      render :action => 'error'
      return
    end
      
    @address = details_response.address
  end
  
  def complete
    purchase = gateway.purchase(5000,
      :ip       => request.remote_ip,
      :payer_id => params[:payer_id],
      :token    => params[:token]
    )
    
    if !purchase.success?
      @message = purchase.message
      render :action => 'error'
      return
    end
  end
  #---------------Paypal Express Checkout-------------------------------
  
  


  #---------------PayPal Website Payments Standard----------------------
  
  def create

  end
  
  def notify
    p request.inspect
    ipn
  end
  
  def ipn
    notify = Paypal::Notification.new(request.raw_post)

    if notify.acknowledge
        begin
          my_file = File.new("filename.txt","w")
          if notify.complete?
              my_file.write "Transaction complete.. add your business logic here"       
              p "Transaction complete.. add your business logic here"
          else
             my_file.write "Transaction not complete, ERROR"
             p "Transaction not complete, ERROR"
          end
  
        rescue => e
          my_file.write "Amit we have a bug"
          p "Amit we have a bug"
        ensure
          my_file.write "Make sure we logged everything we must"
          p "Make sure we logged everything we must"
        end
        my_file.close
      else
        my_file.write "Another reason to be suspicious"
        p "Another reason to be suspicious"
    end

    render :nothing => true
  end
 
 #---------------PayPal Website Payments Standard-----------------------
 
 
 
 
 #---------------Authorize.net Payment gateway integration (AIM) Advance Integration Method-----------------------
   
   def authorize_AIM_payment
    amount_to_charge = Money.ca_dollar(1000) #ten US dollars
      
    creditcard = ActiveMerchant::Billing::CreditCard.new(
    #  :number => '4222222222222', #Authorize.net test card, error-producing
      :number => '4007000000027', #Authorize.net test card, non-error-producing
      :month => 11,                #for test cards, use any date in the future
      :year => 2010,              
      :first_name => 'Amit',      
      :last_name => 'Yadav',
      :type => 'visa'             #note that MasterCard is 'master'
    )

#    if creditcard.valid?
      gatewayObject = ActiveMerchant::Billing::Base.gateway(:authorized_net).new(
        :login => 'XXXXXXXXXX',         #API Login ID
        :password => 'XXXXXXXXXXXXXXXX') #Transaction Key

      options = {
        :address => {},
        :billing_address => { 
          :name     => 'Amit Yadav',
          :address1 => 'TEst Add',
          :city     => 'Test City',
          :state    => 'CA',
          :country  => 'IN',
          :zip      => '201301',
          :phone    => '(555)555-5555'
        }
      }

      response = gatewayObject.authorize(amount_to_charge, creditcard, options)

      if response.success?
        gateway.capture(amount_to_charge, response.authorization)
        @result = "Success: " + response.message.to_s
      else
        @result = "Fail: " + response.message.to_s
      end
#    else
#      @result = "Credit card not valid: " + creditcard.validate.to_s
#    end
  end

 #---------------Authorize.net Payment gateway integration (AIM) Advance Integration Method-----------------------
 
 
 
  #---------------Authorize.net Payment gateway integration (SIM) Server Integration Method-----------------------
  def authorize_SIM_payment
    InsertFP('XXXXXXXXXX', 'XXXXXXXXXXXXXXXX', '0.01', '123TR')
  end

  def hmac(key, data)
    return OpenSSL::HMAC.hexdigest(OpenSSL::Digest::Digest.new('md5'), key, data)
  end
  
  def CalculateFP(loginid, x_tran_key, amount, sequence, tstamp, currency = "")
    return hmac(x_tran_key, loginid + "^" + sequence + "^" + tstamp + "^" + amount + "^" + currency)
  end

  def InsertFP(loginid, x_tran_key, amount, sequence, currency = "")
    tstamp = Time.now.to_i.to_s;
    fingerprint = hmac(x_tran_key, loginid + "^" + sequence + "^" + tstamp + "^" + amount + "^" + currency);
    @str = '<input type="hidden" name="x_fp_sequence" value="' + sequence + '">
            <input type="hidden" name="x_fp_timestamp" value="' + tstamp + '">
             <input type="hidden" name="x_fp_hash" value="' + fingerprint + '">'
    return 0;
  end
  
  def authprize_complete
    @result = request
  end

  #---------------Authorize.net Payment gateway integration (SIM) Server Integration Method-----------------------


  private
  def gateway
    @gateway ||= PaypalExpressGateway.new(
      :login => 'XXXXXXXXXXXXXXXXXXXXXXXXXXXX',
      :password => 'XXXXXXXXXX',
      :signature => 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
    )
  end
end
