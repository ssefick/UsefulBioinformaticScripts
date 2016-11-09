import vcf.filters


class RGQ(vcf.filters.Base):
    'Filter Reference Sites by quality'
    
    name = 'rgq'

    @classmethod
    def customize_parser(self, parser):
        parser.add_argument('--reference-genotype-quality', type=int, default=30,
                help='Filter sites with no genotypes above this quality')

        def __init__(self, args):
            self.threshold = args.reference_genotype_quality

    def __call__(self, record):
        if not record.is_monomorphic:
            rgq = max([x['RGQ'] for x in record if x.is_variant])
            if rgq < self.threshold:
                return vgq
