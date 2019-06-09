# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PrComet::Github::Client do
  let(:client) { described_class.new('GITHUB_ACCESS_TOKEN', remote_url) }
  let(:remote_url) { 'https://github.com/ryz310/pr_comet.git' }
  let(:octokit_mock) do
    instance_double(
      Octokit::Client,
      create_pull_request: OpenStruct.new(number: 123),
      add_labels_to_an_issue: nil,
      projects: [OpenStruct.new(id: 123)],
      project_columns: [
        OpenStruct.new(id: 1, name: 'Column A'),
        OpenStruct.new(id: 2, name: 'Column B')
      ],
      create_project_card: nil
    )
  end

  before { allow(Octokit::Client).to receive(:new).and_return(octokit_mock) }

  describe '#repository' do
    context 'when use https protocol to the git remote URL' do
      let(:remote_url) { 'https://github.com/ryz310/pr_comet.git' }

      it 'returns the github repository name' do
        expect(client.repository).to eq 'ryz310/pr_comet'
      end
    end

    context 'when use git protocol to the git remote URL' do
      let(:remote_url) { 'git@github.com:ryz310/pr_comet.git' }

      it 'returns the github repository name' do
        expect(client.repository).to eq 'ryz310/pr_comet'
      end
    end
  end

  describe '#create_pull_request' do
    subject(:create_pull_request) do
      client.create_pull_request(
        base: 'base', head: 'head', title: 'title', body: 'body'
      )
    end

    it 'calls Octokit::Client#create_pull_request' do
      create_pull_request
      expect(octokit_mock)
        .to have_received(:create_pull_request)
        .with('ryz310/pr_comet', 'base', 'head', 'title', 'body')
    end

    it 'returns created pull request number' do
      expect(create_pull_request).to eq 123
    end
  end

  describe '#add_labels' do
    subject(:add_labels) { client.add_labels(1234, 'label a', 'label b') }

    it 'calls Octokit::Client#add_labels_to_an_issue' do
      add_labels
      expect(octokit_mock)
        .to have_received(:add_labels_to_an_issue)
        .with('ryz310/pr_comet', 1234, ['label a', 'label b'])
    end
  end

  describe '#add_to_project' do
    context 'with project_id' do
      subject(:add_to_project) do
        client.add_to_project(1234, column_name: 'Column A', project_id: 456)
      end

      it 'does not search project ID with the Octokit' do
        add_to_project
        expect(octokit_mock).not_to have_received(:projects)
      end

      it 'searches project columns with a supplied project ID' do
        add_to_project
        expect(octokit_mock).to have_received(:project_columns).with(456)
      end

      it 'adds the issue to the GitHub Project' do
        add_to_project
        expect(octokit_mock).to have_received(:create_project_card)
          .with(1, content_id: 1234, content_type: 'PullRequest')
      end
    end

    context 'without project_id' do
      subject(:add_to_project) do
        client.add_to_project(1234, column_name: 'Column B')
      end

      it 'searches default project ID with the Octokit' do
        add_to_project
        expect(octokit_mock).to have_received(:projects).with('ryz310/pr_comet')
      end

      it 'searches project columns with a default project ID' do
        add_to_project
        expect(octokit_mock).to have_received(:project_columns).with(123)
      end

      it 'adds the issue to the GitHub Project' do
        add_to_project
        expect(octokit_mock).to have_received(:create_project_card)
          .with(2, content_id: 1234, content_type: 'PullRequest')
      end
    end
  end
end
