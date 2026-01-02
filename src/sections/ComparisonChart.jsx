import { Table } from '../components/Table'
import { comparisonChartHeadingContent } from '../constants'

export const ComparisonChart = () => {
  const { headingText, paragraphText } = comparisonChartHeadingContent

  const comparisonData = [
    {
      feature: 'Policy Language',
      kyverno: 'YAML & CEL',
      kyvernoStatus: null,
      opa: 'Rego',
      opaStatus: null,
      kubernetesNative: 'YAML & CEL',
      kubernetesNativeStatus: null,
    },
    {
      feature: 'Ease of Adoption',
      kyverno: 'Intuitive, easy to use',
      kyvernoStatus: null,
      opa: 'Steeper learning curve',
      opaStatus: null,
      kubernetesNative: 'Best, native types',
      kubernetesNativeStatus: null,
    },
    {
      feature: 'K8s Resource Validation',
      kyverno: 'Yes',
      kyvernoStatus: 'yes',
      opa: 'Yes',
      opaStatus: 'yes',
      kubernetesNative: 'limited',
      kubernetesNativeStatus: 'limited',
    },
    {
      feature: 'K8s Resource Mutation',
      kyverno: 'Yes',
      kyvernoStatus: 'yes',
      opa: 'limited',
      opaStatus: 'limited',
      kubernetesNative: 'limited',
      kubernetesNativeStatus: 'limited',
    },
    {
      feature: 'K8s Resource Generation',
      kyverno: 'Yes',
      kyvernoStatus: 'yes',
      opa: 'No',
      opaStatus: 'no',
      kubernetesNative: 'No',
      kubernetesNativeStatus: 'no',
    },
    {
      feature: 'K8s Resource Cleanup',
      kyverno: 'Yes',
      kyvernoStatus: 'yes',
      opa: 'No',
      opaStatus: 'no',
      kubernetesNative: 'No',
      kubernetesNativeStatus: 'no',
    },
    {
      feature: 'Image Verification',
      kyverno: 'Integrated',
      kyvernoStatus: 'yes',
      opa: 'Add-On',
      opaStatus: 'limited',
      kubernetesNative: 'Not supported',
      kubernetesNativeStatus: 'no',
    },
    {
      feature: 'Background Scans',
      kyverno: 'Yes',
      kyvernoStatus: 'yes',
      opa: 'Yes',
      opaStatus: 'yes',
      kubernetesNative: 'No',
      kubernetesNativeStatus: 'no',
    },
    {
      feature: 'Shift-Left, CI/CD Integration',
      kyverno: 'Yes',
      kyvernoStatus: 'yes',
      opa: 'Yes',
      opaStatus: 'yes',
      kubernetesNative: 'No',
      kubernetesNativeStatus: 'no',
    },
    {
      feature: 'JSON Payloads',
      kyverno: 'Yes',
      kyvernoStatus: 'yes',
      opa: 'Yes',
      opaStatus: 'yes',
      kubernetesNative: 'No',
      kubernetesNativeStatus: 'no',
    },
    {
      feature: 'Integrated Reporting',
      kyverno: 'Yes',
      kyvernoStatus: 'yes',
      opa: 'No',
      opaStatus: 'no',
      kubernetesNative: 'No',
      kubernetesNativeStatus: 'no',
    },
    {
      feature: 'Exceptions',
      kyverno: 'Yes',
      kyvernoStatus: 'yes',
      opa: 'No',
      opaStatus: 'no',
      kubernetesNative: 'No',
      kubernetesNativeStatus: 'no',
    },
    {
      feature: 'Test Tooling',
      kyverno: 'Yes',
      kyvernoStatus: 'yes',
      opa: 'Yes',
      opaStatus: 'yes',
      kubernetesNative: 'Yes',
      kubernetesNativeStatus: 'no',
    },
  ]

  return (
    <section className="flex flex-col justify-center items-center pb-6 px-6">
      <div className="items-center flex flex-col space-y-6 my-5">
        <h2 className="text-4xl font-bold tracking-wide text-center">
          Kyverno <span className="lowercase">vs</span>
          <span className="text-primary-100"> Other policy engines</span>
        </h2>
        <p className="min-w-80 text-[1rem] w-80 sm:text-lg sm:min-w-150 text-center text-white/80">
          As the industry's leading policy engine, here's how Kyverno compares
          with other policy engines.
        </p>
      </div>
      <div
        className="flex justify-center items-center w-full md:max-w-260 
        bg-dark-50 border border-stroke p-6 rounded-2xl sm:overflow-x-auto text-[16px] mt-8"
      >
        <Table data={comparisonData} />
      </div>
    </section>
  )
}
