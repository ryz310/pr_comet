# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PrComet::Git::Command do
  let(:command) { described_class.new(**params) }
  let(:params) do
    { user_name: nil, user_email: nil, verbose: false }
  end

  before { allow(command).to receive(:execute) }

  describe '#user_name' do
    before do
      allow(command)
        .to receive(:execute)
        .with('git config user.name')
        .and_return('Git User Name')
    end

    context 'with `user_name` on initializing arguments' do
      let(:params) { { user_name: 'Rubocop Challenger' } }

      it 'returns `user_name` from arguments' do
        expect(command.user_name).to eq 'Rubocop Challenger'
      end
    end

    context 'without `user_name` on initializing arguments' do
      it 'returns `user_name` from `$ git config user.name`' do
        expect(command.user_name).to eq 'Git User Name'
      end
    end
  end

  describe '#user_email' do
    before do
      allow(command)
        .to receive(:execute)
        .with('git config user.email')
        .and_return('git-user-email@example.com')
    end

    context 'with `user_email` on initializing arguments' do
      let(:params) { { user_email: 'rubocop-challenger@example.com' } }

      it 'returns `user_email` from arguments' do
        expect(command.user_email).to eq 'rubocop-challenger@example.com'
      end
    end

    context 'without `user_email` on initializing arguments' do
      it 'returns `user_email` from `$ git config user.email`' do
        expect(command.user_email).to eq 'git-user-email@example.com'
      end
    end
  end

  describe '#exist_uncommitted_modify?' do
    subject(:execute) { command.exist_uncommitted_modify? }

    it do
      execute
      expect(command)
        .to have_received(:execute)
        .with('git add -n .; git diff --name-only')
    end

    context 'when exist uncommitted modify' do
      before { allow(command).to receive(:execute).and_return('foo.rb') }

      it { is_expected.to be_truthy }
    end

    context 'when does not exist uncommitted modify' do
      before { allow(command).to receive(:execute).and_return('') }

      it { is_expected.to be_falsey }
    end
  end

  describe '#checkout' do
    it do
      command.checkout('{branch}')
      expect(command).to have_received(:execute).with('git checkout {branch}')
    end
  end

  describe '#checkout_with' do
    it do
      command.checkout_with('{new branch}')
      expect(command)
        .to have_received(:execute)
        .with('git checkout -b {new branch}')
    end
  end

  describe '#add' do
    it do
      command.add('.')
      expect(command).to have_received(:execute).with('git add .')
    end

    it do
      command.add('foo.rb', 'bar.rb')
      expect(command).to have_received(:execute).with('git add foo.rb bar.rb')
    end
  end

  describe '#commit' do
    before do
      allow(command).to receive_messages(user_name: 'CommitterName', user_email: 'committer@example.com')
    end

    let(:expected_command) do
      'GIT_AUTHOR_NAME="CommitterName" ' \
      'GIT_AUTHOR_EMAIL="committer@example.com" ' \
      'GIT_COMMITTER_NAME="CommitterName" ' \
      'GIT_COMMITTER_EMAIL="committer@example.com" ' \
      'git commit -m "message"'
    end

    it do
      command.commit('message')
      expect(command).to have_received(:execute).with(expected_command)
    end
  end

  describe '#push' do
    context 'with a branch argument' do
      it do
        command.push('origin', 'new_branch')
        expect(command)
          .to have_received(:execute)
          .with('git push -q origin new_branch')
      end
    end

    context 'without branch argument' do
      before do
        allow(command).to receive(:current_branch).and_return('current_branch')
      end

      it do
        command.push('origin')
        expect(command)
          .to have_received(:execute)
          .with('git push -q origin current_branch')
      end
    end
  end

  describe '#current_sha1' do
    it do
      command.current_sha1
      expect(command).to have_received(:execute).with('git rev-parse HEAD')
    end
  end

  describe '#current_sha1?' do
    subject { command.current_sha1?('currentsha1') }

    context 'when current sha-1 and argument ones are same' do
      before do
        allow(command).to receive(:current_sha1).and_return('currentsha1')
      end

      it { is_expected.to be_truthy }
    end

    context 'when current sha-1 and argument ones are different' do
      before do
        allow(command).to receive(:current_sha1).and_return('anothersha1')
      end

      it { is_expected.to be_falsey }
    end
  end

  describe '#current_branch' do
    it do
      command.current_branch
      expect(command)
        .to have_received(:execute)
        .with('git rev-parse --abbrev-ref HEAD')
    end
  end

  describe '#current_branch?' do
    subject { command.current_branch?('branch_name') }

    context 'when current branch name and argument ones are same' do
      before do
        allow(command).to receive(:current_branch).and_return('branch_name')
      end

      it { is_expected.to be_truthy }
    end

    context 'when current branch name and argument ones are different' do
      before do
        allow(command).to receive(:current_branch).and_return('another_branch')
      end

      it { is_expected.to be_falsey }
    end
  end

  describe '#remote_url' do
    it do
      command.remote_url('origin')
      expect(command)
        .to have_received(:execute)
        .with('git config --get remote.origin.url')
    end
  end
end
