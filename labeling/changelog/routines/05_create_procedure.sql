CREATE OR REPLACE PROCEDURE lab.sp_apply_label_to_item(
    p_item_id BIGINT,
    p_label_key VARCHAR(100)
)
LANGUAGE plpgsql
AS 'DECLARE
    v_label_id BIGINT;
BEGIN
    SELECT label_id
    INTO v_label_id
    FROM lab.labels
    WHERE label_key = p_label_key;

    IF v_label_id IS NULL THEN
        INSERT INTO lab.labels (label_key, description)
        VALUES (p_label_key, ''Auto-created by sp_apply_label_to_item'')
        RETURNING label_id INTO v_label_id;
    END IF;

    INSERT INTO lab.work_item_labels (item_id, label_id)
    VALUES (p_item_id, v_label_id)
    ON CONFLICT (item_id, label_id) DO NOTHING;
END;';
