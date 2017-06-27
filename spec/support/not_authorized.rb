
# Shared examples to ensure a non-admin cannot access the page.
shared_examples 'not authorized when non-admin logged in' do
  context 'when non-admin user logged in' do
    include_context 'login non-admin user'

    it 'returns not authorized' do
      request
      expect(page).to have_content 'Unauthorized'
    end
  end
end
