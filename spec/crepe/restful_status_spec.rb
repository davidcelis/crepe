require 'spec_helper'

describe Crepe::API, 'RESTful status' do
  app do
    post   '/post'   do { created_at: Time.now } end
    put    '/put'    do { updated_at: Time.now } end
    patch  '/patch'  do { updated_at: Time.now } end
    delete '/delete' do { deleted_at: Time.now } end
    namespace :empty do
      post   '/post'
      put    '/put'
      patch  '/patch'
      delete '/delete'
    end
  end

  %w[post put patch delete].each do |method|
    if method == 'post'
      it "returns 201 Created for POSTs with content" do
        post('/post').status.should eq 201
      end
    else
      it "returns 200 OK for #{method.upcase}s with content" do
        send(method, "/#{method}").status.should eq 200
      end
    end

    it "returns 204 No Content for #{method.upcase}s without content" do
      send(method, "/empty/#{method}").status.should eq 204
    end
  end
end
