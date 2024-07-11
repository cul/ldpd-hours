module EditLocationHelper
  # <label for="location_access_points_2"><input type="checkbox" value="2" name="location[access_points][]" id="location_access_points_2" />2 (Location 2)</label>
  def access_point_checkboxes(access_point_branches, count_iterator, current_values = [])
    content_tag(:ul) do
      access_point_branches.map do |branch|
        branch_tag = content_tag(:li) do
          cb_index = count_iterator.next
          content_tag(:label, for: "location_access_points_#{cb_index}") do
            checked = current_values.include?(branch.id)
            tag(:input, type: 'checkbox', value: branch.id, name: "location[access_points][]", id: "location_access_points_#{cb_index}", checked: checked).safe_concat("#{branch.name} #{branch.updated_at}")
          end
        end
        if branch.children.size > 0
          child_tag = content_tag(:li) do
            access_point_checkboxes(branch.children.values, count_iterator)
          end
          branch_tag.safe_concat child_tag
        end
        branch_tag
      end.join.html_safe
    end
  end
end