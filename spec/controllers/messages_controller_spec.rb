require 'spec_helper'

describe MessagesController do
  include_context "inherited_resources"

  let(:current_user) { User.make! }

  before do
    sign_in_user(current_user)
  end

  context "startup" do
    let(:startup) { Startup.make! }

    before do
      startup.attach_user(current_user)
    end

    it "accepts comments" do
      post :create, :startup_id => startup.id, :message => { :content => 'hello world' }

      startup.reload

      startup.comments.first.content.should == 'hello world'
    end
  end

  context "private messages" do
    let(:target_user) { User.make! }

    before do
      current_user.send_private_message(target_user, 'Hello there!')
    end

    it "shows a topic" do
      get :show_private_message, :id => 1

      assigns(:topic).should == Message.topics.find(1)
    end

    it "replies to a topic" do
      post :reply_private_message, :id => 1, :message => { :content => 'Yes dear!' }

      topic = Message.topics.find(1)

      assigns(:topic).should == topic
      topic.replies.first.content.should == 'Yes dear!'
    end
  end
end
