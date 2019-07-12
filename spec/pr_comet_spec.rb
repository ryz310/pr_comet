# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PrComet do
  let(:pr_comet) do
    described_class.new(base: 'master', branch: 'topic_branch')
  end

  let(:git_command) do
    instance_double(
      PrComet::Git::Command,
      add: '',
      commit: '',
      push: '',
      remote_url: 'git@github.com:ryz310/rubocop_challenger.git',
      current_sha1: '1234567890',
      'current_sha1?': false,
      'current_branch?': true,
      'exist_uncommitted_modify?': false
    )
  end

  let(:github_client) do
    instance_double(
      PrComet::Github::Client,
      create_pull_request: 1234,
      repository: 'ryz310/rubocop_challenger',
      add_labels: '',
      add_to_project: ''
    )
  end

  before do
    allow(PrComet::Git::Command).to receive(:new).and_return(git_command)
    allow(PrComet::Github::Client).to receive(:new).and_return(github_client)
  end

  describe '#commit' do
    context 'with &block' do
      subject(:commit) do
        pr_comet.commit('commit message') { 123 }
      end

      it 'returns result of yield' do
        expect(commit).to eq 123
      end

      it do
        commit
        expect(git_command).to have_received(:commit).with('commit message')
      end
    end

    context 'without &block' do
      subject(:commit) do
        pr_comet.commit 'commit message'
      end

      it { is_expected.to be_nil }

      it do
        commit
        expect(git_command).to have_received(:commit).with('commit message')
      end
    end
  end

  describe '#create!' do
    subject(:create!) do
      pr_comet.create!(
        title: 'The pull request title',
        body: 'The pull request body',
        labels: labels,
        project_column_name: project_column_name,
        project_id: project_id,
        validate: validate
      )
    end

    let(:labels) { nil }
    let(:project_column_name) { nil }
    let(:project_id) { nil }
    let(:validate) { true }

    shared_examples 'to call create pull request API' do
      let(:expected_parameters) do
        {
          base: 'master',
          head: 'topic_branch',
          title: 'The pull request title',
          body: 'The pull request body'
        }
      end

      let(:expected_remote_url) do
        'https://${GITHUB_ACCESS_TOKEN}@github.com/ryz310/rubocop_challenger'
      end

      it { is_expected.to be_truthy }

      it do
        create!
        expect(git_command)
          .to have_received(:push)
          .with(expected_remote_url, 'topic_branch')
      end

      it do
        create!
        expect(github_client)
          .to have_received(:create_pull_request)
          .with(expected_parameters)
      end
    end

    shared_examples 'not to call create pull request API' do
      let(:expected_parameters) do
        {
          base: 'master',
          head: 'topic_branch',
          title: 'The pull request title',
          body: 'The pull request body'
        }
      end

      it { is_expected.to be_falsey }

      it do
        create!
        expect(git_command).not_to have_received(:push)
      end

      it do
        create!
        expect(github_client).not_to have_received(:create_pull_request)
      end
    end

    context 'with labels option' do
      let(:labels) { ['label a', 'label b'] }

      it_behaves_like 'to call create pull request API' do
        it do
          create!
          expect(github_client)
            .to have_received(:add_labels)
            .with(1234, 'label a', 'label b')
        end
      end
    end

    context 'without labels option' do
      it_behaves_like 'to call create pull request API' do
        it do
          create!
          expect(github_client).not_to have_received(:add_labels)
        end
      end
    end

    context 'with project_column_name option' do
      let(:project_column_name) { 'Column name' }

      context 'with project_id' do
        let(:project_id) { 456 }

        it_behaves_like 'to call create pull request API' do
          it do
            create!
            expect(github_client).to have_received(:add_to_project)
              .with(1234, column_name: 'Column name', project_id: 456)
          end
        end
      end

      context 'without project_id' do
        it_behaves_like 'to call create pull request API' do
          it do
            create!
            expect(github_client).to have_received(:add_to_project)
              .with(1234, column_name: 'Column name', project_id: nil)
          end
        end
      end
    end

    context 'without project_column_name option' do
      it_behaves_like 'to call create pull request API' do
        it do
          create!
          expect(github_client).not_to have_received(:add_to_project)
        end
      end
    end

    context 'when no commit' do
      before do
        allow(git_command)
          .to receive(:current_sha1?).with('1234567890').and_return(true)
      end

      context 'with "validate false" option' do
        let(:validate) { false }

        it_behaves_like 'to call create pull request API'
      end

      context 'without "validate" option' do
        it_behaves_like 'not to call create pull request API'
      end
    end

    context 'when no checkout' do
      before do
        allow(git_command)
          .to receive(:current_branch?).with('topic_branch').and_return(false)
      end

      context 'with "validate false" option' do
        let(:validate) { false }

        it_behaves_like 'to call create pull request API'
      end

      context 'without "validate" option' do
        it_behaves_like 'not to call create pull request API'
      end
    end
  end

  describe 'VERSION' do
    it 'has a version number' do
      expect(PrComet::VERSION).not_to be_nil
    end
  end
end
