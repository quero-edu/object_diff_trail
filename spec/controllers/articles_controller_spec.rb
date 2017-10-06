require "spec_helper"

RSpec.describe ArticlesController, type: :controller do
  describe "ObjectDiffTrail.enabled_for_controller?" do
    context "ObjectDiffTrail.enabled? == true" do
      before { ObjectDiffTrail.enabled = true }

      it "returns true" do
        assert ObjectDiffTrail.enabled?
        post :create, params_wrapper(article: { title: "Doh", content: FFaker::Lorem.sentence })
        expect(assigns(:article)).not_to be_nil
        assert ObjectDiffTrail.enabled_for_controller?
        assert_equal 1, assigns(:article).versions.length
      end

      after { ObjectDiffTrail.enabled = false }
    end

    context "ObjectDiffTrail.enabled? == false" do
      it "returns false" do
        assert !ObjectDiffTrail.enabled?
        post :create, params_wrapper(article: { title: "Doh", content: FFaker::Lorem.sentence })
        assert !ObjectDiffTrail.enabled_for_controller?
        assert_equal 0, assigns(:article).versions.length
      end
    end
  end
end
