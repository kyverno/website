import { HeadingContent } from '../components/HeadingContent'
import { Table } from '../components/Table'
import { comparisonChartHeadingContent } from '../constants'

export const ComparisonChart = () => {
  const { headingText, paragraphText } = comparisonChartHeadingContent

  return (
    <section className="flex flex-col justify-center items-center pb-6 px-6">
      <div className="items-center flex flex-col space-y-6 my-5">
        <HeadingContent
          headingParts={headingText}
          subheading={paragraphText}
          variant="level2"
          headerLevel="h2"
        />
      </div>
      <div
        className="flex justify-center items-center w-full md:max-w-260 
        bg-dark-50 border border-stroke p-6 rounded-2xl sm:overflow-x-auto text-[16px] mt-8"
      >
        <Table />
      </div>
    </section>
  )
}
