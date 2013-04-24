require 'spec_helper'

describe Crepe::Filter::Acceptance do
  app do
    respond_to :json

    get do
      { hello: 'world' }
    end
  end

  context 'unacceptable content' do
    it 'renders Not Acceptable' do
      get '/.xml'
      last_response.body.should eq(JSON.dump(
        error: { accepts: ['application/json'], message: 'Not Acceptable' }
      ))
    end
  end
end
