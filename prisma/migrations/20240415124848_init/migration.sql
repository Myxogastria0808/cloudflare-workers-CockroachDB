-- CreateTable
CREATE TABLE "Blog" (
    "cockroachdbId" INT8 NOT NULL DEFAULT unique_rowid(),
    "title" STRING NOT NULL,
    "content" STRING NOT NULL,

    CONSTRAINT "Blog_pkey" PRIMARY KEY ("cockroachdbId")
);
