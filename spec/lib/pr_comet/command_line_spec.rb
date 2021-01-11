# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PrComet::CommandLine do
  let(:command_line) do
    mock_class = Class.new do
      include PrComet::CommandLine
    end
    mock_class.new
  end

  describe '#execute' do
    subject(:execute) { command_line.send(:execute, command) }

    context 'with verbose: true' do
      before do
        allow(command_line).to receive(:verbose).and_return(true)
      end

      context 'when the execution was succeeded' do
        let(:command) { 'echo Hello world' }

        it 'returns a executed command standard output' do
          expect(execute).to eq 'Hello world'
        end

        it 'outputs the command execution to stdout with color code GREEN' do
          expect { execute }.to output(<<~STDOUT).to_stdout
            $ echo Hello world
            \e[32mHello world\e[0m
          STDOUT
        end
      end

      context 'when the execution was failed' do
        let(:command) { 'echo Hello world && false' }

        it 'returns a executed command standard output' do
          expect(execute).to eq 'Hello world'
        end

        it 'outputs the command execution to stdout with color code RED' do
          expect { execute }.to output(<<~STDOUT).to_stdout
            $ echo Hello world && false
            \e[31mHello world\e[0m
          STDOUT
        end
      end
    end

    context 'with verbose: false' do
      before do
        allow(command_line).to receive(:verbose).and_return(false)
      end

      let(:command) { 'echo Hello world' }

      it 'returns a executed command standard output' do
        expect(execute).to eq 'Hello world'
      end

      it 'does not output the command execution to stdout' do
        expect { execute }.not_to output.to_stdout
      end
    end
  end
end
