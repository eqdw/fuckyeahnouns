require './sources/bing.rb'

describe 'Bing' do

  describe '.process_json' do
    subject do
      open('./spec/support/bing.json') do |json|
        Bing.process_json(JSON.parse(json.read))
      end
    end

    its([:total])  { should equal 50 }
    its([:images]) { should respond_to :each }
  end

  describe '.fetch' do
    before do
      Bing.stub(:query) do
        {
          "d" => {
            "results" => [
              { 'MediaUrl' => 'http://example.com/example.jpg'}
            ]
          }
        }
      end

      Kernel.stub(:open) do
        open('./spec/support/test_image.jpg')
      end
    end

    let(:subject)     { Bing.fetch('xbox') }
    its(:images)      { should respond_to(:each) }
    its(:images)      { should == ['http://example.com/example.jpg'] }
  end
end
