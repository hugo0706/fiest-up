# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Oauth::SessionsController, type: :controller do
  describe 'GET #login' do
    let(:user_scopes) { %w[user-read-private user-read-email] }
    let(:state) { 'securerandomstat' }
    let(:redirect_uri) { 'http://localhost:3000/auth/callback' }
    let(:client_id) { 'test_client_id' }
    let(:state) { 'state' }
    let(:redirect_url) {
      "https://accounts.spotify.com/authorize?" \
        "client_id=#{client_id}" \
        "&redirect_uri=#{CGI.escape(redirect_uri)}" \
        "&response_type=code" \
        "&scope=#{user_scopes.join('+')}" \
        "&state=#{state}"
    }
    before do
      expect_any_instance_of(Spotify::Oauth::AuthorizeService).to receive(:get_state_and_authorize_url)
        .and_return([ state, redirect_url ])
    end

    it 'redirects user to Spotify authorization endpoint and stores the state of the redirection in session hash' do
      get :login

      expect(response).to redirect_to(redirect_url)
      expect(response.status).to eq(302)
      expect(session[:oauth_state]).to eq(state)
    end
  end

  describe 'GET #callback' do
    let!(:params) {
      {
        code: code,
        state: state
      }
    }
    let(:code) { 'code' }
    let(:state) { 'state' }


    context 'when parameters are correct' do
      shared_examples_for 'redirect to home page with error' do
        it 'redirects the user to start page with an error flash' do
          get :callback, params: params

          expect(response).to redirect_to(start_path)
          expect(flash[:error]).to eq("An unexpected error ocurred while login in")
        end
      end

      context 'when there is no error field in parameters' do
        let(:user) { create(:user) }

        before do
          expect(UserFetcherService).to receive(:new).with(code).and_call_original
          expect_any_instance_of(UserFetcherService).to receive(:call)
            .and_return(user)
          session[:oauth_state] = state
        end

        context 'when the user was creating an account' do
          it "calls UserFetcherService with the code parameter, " \
            "stores the user session and redirects to home" do
            get :callback, params: params

            expect(session[:user_id]).to eq(user.id)
            expect(flash[:notice]).to eq('Logged in!')
            expect(response).to redirect_to(home_path)
          end
        end

        context 'when the user was joining a party and created an account' do
          before { session[:joining_party_code] = code }

          it "calls UserFetcherService with the code parameter, " \
             "stores the user session and redirects to the join party path" do
            get :callback, params: params

            expect(session[:user_id]).to eq(user.id)
            expect(flash[:notice]).to eq('Joining party with your Spotify account!')
            expect(response).to redirect_to(join_party_path(code: code))
          end

          it 'empties the joining_party_code session cookie and stores its value' do
            get :callback, params: params

            expect(session[:joining_party_code]).to eq(nil)
            expect(assigns(:joining_party_code)).to eq(code)
          end
        end
      end

      context 'when there is an error field in the parameters' do
        let!(:params) { super().merge!({ error: 'error' }) }

        it_behaves_like 'redirect to home page with error'
      end

      context 'when either state or code fields are missing or the state is not correct' do
        before { params.delete(:code) }

        it_behaves_like 'redirect to home page with error'
      end

      context 'when UserCreatorService::InvalidUserError is raised' do
        before { allow(UserCreatorService).to receive(:new)
                  .and_raise(UserCreatorService::InvalidUserError) }

        it_behaves_like 'redirect to home page with error'
      end

      context 'when Spotify::Oauth::AccesTokenService::Error is raised' do
        before { allow(Spotify::Oauth::AuthorizeService).to receive(:new)
                  .and_raise(Spotify::Oauth::AccessTokenService::Error) }

        it_behaves_like 'redirect to home page with error'
      end

      context 'when  Spotify::Api::CurrentProfileService::Error is raised' do
        before { allow(Spotify::Api::CurrentProfileService).to receive(:new)
                  .and_raise(Spotify::Api::CurrentProfileService::Error) }

        it_behaves_like 'redirect to home page with error'
      end
    end
  end
end
