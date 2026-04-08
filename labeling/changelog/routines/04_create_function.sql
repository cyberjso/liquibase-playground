CREATE OR REPLACE FUNCTION lab.fn_label_count_for_item(p_item_id BIGINT)
RETURNS INTEGER
LANGUAGE SQL
AS 'SELECT COUNT(*)::INTEGER FROM lab.work_item_labels WHERE item_id = $1';
