require 'spec_helper'

module Sunspot
  module Rails
    describe Failover do
      describe '.setup' do
        let(:configuration) { double('configuration') }
        let(:slave_config) { double('slave_config') }
        let(:master_config) { double('master_config') }
    
        before do
          Rails.stub(:configuration).and_return(configuration)
          Rails.stub(:slave_config).and_return(slave_config)
          Rails.stub(:master_config).and_return(master_config)
        end
    
        context 'with a master configuration' do
          before do
            configuration.should_receive(:has_master?).and_return(true)
          end
      
          let(:proxy)          { double('master_slave_failover_proxy') }
          let(:master_session) { double('master_session') }
          let(:slave_session)  { double('slave_session') }
      
          it 'sets the session to master/slave with failover support' do        
            SessionProxy::ThreadLocalSessionProxy.should_receive(:new).with(master_config).and_return(master_session)
            SessionProxy::ThreadLocalSessionProxy.should_receive(:new).with(slave_config).and_return(slave_session)
        
            SessionProxy::MasterSlaveWithFailoverSessionProxy.should_receive(:new).with(
              master_session, slave_session
            ).and_return(proxy)
        
            described_class.setup
            Sunspot.session.should eq(proxy)
          end
        end
    
        context 'with no master configuration' do
          before do
            configuration.should_receive(:has_master?).and_return(false)
          end
      
          let(:proxy) { double('thread_local_proxy') }
          
          it 'sets the session to the default proxy' do
            SessionProxy::ThreadLocalSessionProxy.should_receive(:new).with(slave_config).and_return(proxy)
        
            described_class.setup
            Sunspot.session.should eq(proxy)
          end
        end
    
      end
    end
  end
end