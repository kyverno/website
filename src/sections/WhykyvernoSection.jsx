
import { Tag } from "../components/Tag";
import { whyKyvernoCards, cardColors1, whykyvernoHeadingContent} from "../constants";
import { WhykyvCard } from "../components/WhykyvCard";
import { HeadingContent } from "../components/HeadingContent";


export const WhykyvernoSection = () => {

    const {headingText, paragraphText} = whykyvernoHeadingContent;

    return (
        <section className="p-20 flex flex-col items-center space-y-5" id="whykyverno">
            <Tag variant='secondary'>Created by Nirmata</Tag>
            <div className="items-center flex flex-col space-y-6 my-5">
                <HeadingContent
                    headingParts={headingText}
                    subheading={paragraphText}
                    variant="level2"
                    headerLevel="h2"
                />
            </div>
            <div className="w-full flex flex-col space-y-4 justify-center md:flex-row md:flex-wrap md:content-baseline
            md:space-x-4 md:mt-8 lg:flex-nowrap">
                    {whyKyvernoCards.map((card, index) => (
                        <WhykyvCard card={card} color={cardColors1[index]} key={index}/>
                    ))}
            </div>
        </section>
    )
}
