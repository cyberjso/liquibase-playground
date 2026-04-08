CREATE SEQUENCE IF NOT EXISTS lab.seq_labels START WITH 1000 INCREMENT BY 1;
CREATE SEQUENCE IF NOT EXISTS lab.seq_work_items START WITH 1000 INCREMENT BY 1;
CREATE SEQUENCE IF NOT EXISTS lab.seq_work_item_labels START WITH 1000 INCREMENT BY 1;

ALTER TABLE lab.labels
    ALTER COLUMN label_id SET DEFAULT nextval('lab.seq_labels');

ALTER TABLE lab.work_items
    ALTER COLUMN item_id SET DEFAULT nextval('lab.seq_work_items');

ALTER TABLE lab.work_item_labels
    ALTER COLUMN work_item_label_id SET DEFAULT nextval('lab.seq_work_item_labels');
