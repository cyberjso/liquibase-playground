CREATE SCHEMA IF NOT EXISTS lab;

CREATE TABLE IF NOT EXISTS lab.labels (
    label_id BIGINT PRIMARY KEY,
    label_key VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS lab.work_items (
    item_id BIGINT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    status VARCHAR(40) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS lab.work_item_labels (
    work_item_label_id BIGINT PRIMARY KEY,
    item_id BIGINT NOT NULL,
    label_id BIGINT NOT NULL,
    applied_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_work_item_labels_item
        FOREIGN KEY (item_id)
        REFERENCES lab.work_items (item_id),
    CONSTRAINT fk_work_item_labels_label
        FOREIGN KEY (label_id)
        REFERENCES lab.labels (label_id),
    CONSTRAINT uq_work_item_label UNIQUE (item_id, label_id)
);
