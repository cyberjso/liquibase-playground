CREATE INDEX IF NOT EXISTS idx_work_items_status
    ON lab.work_items (status);

CREATE INDEX IF NOT EXISTS idx_work_item_labels_item_id
    ON lab.work_item_labels (item_id);

CREATE INDEX IF NOT EXISTS idx_work_item_labels_label_id
    ON lab.work_item_labels (label_id);

CREATE INDEX IF NOT EXISTS idx_labels_label_key
    ON lab.labels (label_key);
