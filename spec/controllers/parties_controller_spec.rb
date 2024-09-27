# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PartiesController, type: :controller do
  describe 'POST #create' do
    let(:name) { 'party' }
    let(:params) do
      {
        name: name
      }
    end

    context 'when user is logged in' do
      let(:user) { create(:user) }

      before do
        session[:user_id] = user.id
      end

      context 'when creating a party' do
        context 'with a code that already exists' do
          let(:existing_party_code) { '123456' }
          let(:non_existing_party_code) { 'qwerty' }
          let(:existing_party_name) { 'existing_name' }
          let!(:existing_party) do
            create(:party, user: user, code: existing_party_code, name: existing_party_name)
          end
          context 'when retries are not depleted' do
            before do
              allow(SecureRandom).to receive(:hex).with(3)
                .and_return(existing_party_code, existing_party_code, non_existing_party_code)
            end

            it 'creates a party with the non repeated unique party code and adds the owner to it' do
              expect { post :create, params: params }.to change { Party.count }.from(1).to(2)
              expect(Party.last.code).to eq(non_existing_party_code)
              expect(Party.last.users).to eq([ user ])
            end
          end

          context 'when retries are depleted' do
            before do
              allow(SecureRandom).to receive(:hex).with(3)
                .and_return(existing_party_code, existing_party_code, existing_party_code)
            end

            it 'raises RetriesDepleted error, reports the error and redirects to home' do
              expect(controller).to receive(:raise).with(PartiesController::RetriesDepleted).and_call_original
              expect(controller).to receive(:report_error).with(PartiesController::RetriesDepleted).and_call_original

              post :create, params: params

              expect(flash[:error]).to eq('There was an error creating the party')
              expect(response).to redirect_to(home_path)
            end
          end
        end

        context 'with a name that already exists for the user' do
          let!(:existing_party) { create(:party, user: user, name: name) }

          it 'raises PartyAlreadyExists error, reports the error and redirects to home' do
            expect(controller).to receive(:raise).with(PartiesController::PartyAlreadyExists).and_call_original
            expect(controller).to receive(:report_error).with(PartiesController::PartyAlreadyExists).and_call_original

            post :create, params: params

            expect(flash[:error]).to eq('You already have a party with that name')
            expect(response).to redirect_to(home_path)
          end
        end

        context 'with valid attributes' do
          it 'creates a party and adds the owner to it' do
            post :create, params: params

            expect(flash[:notice]).to eq('Party created succesfully')
            expect(response).to redirect_to(show_party_path(user.parties.last.code))
            expect(user.parties).to eq([ Party.last ])
            expect(Party.last.users).to eq([ user ])
          end

          context 'with a party name that corresponds to other user' do
            before { create(:party, name: name) }

            it 'creates a party and adds the owner to it' do
              post :create, params: params

              expect(flash[:notice]).to eq('Party created succesfully')
              expect(response).to redirect_to(show_party_path(user.parties.last.code))
              expect(user.parties).to eq([ Party.last ])
              expect(Party.last.users).to eq([ user ])
            end
          end
        end
      end
    end

    context 'when user is not logged in' do
      it 'redirects the user to start page' do
        post :create, params: params

        expect(response).to redirect_to(start_path)
      end
    end
  end

  describe 'GET #join' do
    context 'when the party does not exist' do
      it 'redirects to start path with a flash error message' do
        get :join, params: { code: 'fakecode' }

        expect(response).to redirect_to(start_path)
        expect(flash[:error]).to eq('That party does not exist')
      end
    end

    context 'when the party code exists' do
      let(:code) { 'c1o2d3' }
      let!(:existing_party) { create(:party, code: code) }

      context 'when the user is logged in' do
        let(:user) { create(:user) }

        before { session[:user_id] = user.id }

        it 'adds the user to the party and redirects to party' do
          get :join, params: { code: code }

          expect(flash[:notice]).to eq("Party joined!")
          expect(response).to redirect_to(show_party_path(code: code))
          expect(existing_party.party_users.exists?(user: user)).to eq(true)
        end
      end

      context 'when the user is not logged in' do
        it 'adds the party code that he is joining to cookies and renders non_logged_join view' do
          get :join, params: { code: code }

          expect(session[:joining_party_code]).to eq(code)
          expect(response).to render_template('non_logged_join')
        end
      end
    end
  end

  describe 'callbacks' do
    describe 'user_in_party?' do
      let(:code) { 'code12' }
      let!(:party) { create(:party, code: code) }

      context 'when the user belongs to the party' do
        context 'when it is a normal user' do
          let(:user) { create(:user) }

          before do
            session[:user_id] = user.id
            party.users << user
          end

          it 'allows access to party show' do
            get :show, params: { code: code }

            expect(response.status).to eq(200)
          end
        end

        context 'when it is a temporal user' do
          let(:user) { create(:temporal_user) }

          before do
            session[:temporal_session] = user.id
            party.temporal_users << user
          end

          it 'allows access to party show' do
            get :show, params: { code: code }

            expect(response.status).to eq(200)
          end
        end
      end

      context 'when the user does not belong to the party' do
        context 'when it is a normal user' do
          let(:user) { create(:user) }

          before { session[:user_id] = user.id }

          it 'redirects the user to join party path with an error message' do
            get :show, params: { code: code }

            expect(response).to redirect_to(join_party_path(code: code))
            expect(flash[:error]).to eq('You have to join the party first')
          end
        end

        context 'when it is a temporal user' do
          let(:user) { create(:temporal_user) }

          before { session[:temporal_session] = user.id }

          it 'redirects the user to join party path with an error message' do
            get :show, params: { code: code }

            expect(response).to redirect_to(join_party_path(code: code))
            expect(flash[:error]).to eq('You have to join the party first')
          end
        end
      end

      context 'when there is no session' do
        it 'redirects the user to join party path with an error message' do
          get :show, params: { code: code }

          expect(response).to redirect_to(join_party_path(code: code))
          expect(flash[:error]).to eq('You have to join the party first')
        end
      end
    end
  end
end
