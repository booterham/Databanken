create table artikel_super
(
    articletitle varchar,
    year         varchar,
    journal      varchar,
    firstname    varchar,
    lastname     varchar,
    laboratory   varchar,
    institution  varchar
);

create table inhoud_super
(
    articletitle       varchar,
    year               varchar,
    journal            varchar,
    sectiontitle       varchar,
    sectionnr          varchar,
    sectiontext        varchar,
    specialcontenttype varchar,
    specialcontentnr   varchar,
    caption            varchar
);

create table referenties_super
(
    cited_articletitle  varchar,
    cited_year          varchar,
    cited_journal       varchar,
    citing_articletitle varchar,
    citing_year         varchar,
    citing_journal      varchar
);