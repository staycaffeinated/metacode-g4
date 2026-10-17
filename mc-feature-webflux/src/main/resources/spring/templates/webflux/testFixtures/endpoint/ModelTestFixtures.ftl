<#include "/common/Copyright.ftl">
package ${ModelTestFixtures.packageName()};

import ${EntityResource.fqcn()};
import reactor.core.publisher.Flux;

import java.util.ArrayList;
import java.util.List;

public class ${ModelTestFixtures.className()} {

    public static final List<${EntityResource.className()}> ALL_ITEMS = allItems();
    public static final Flux<${EntityResource.className()}> FLUX_ITEMS = Flux.fromIterable(ALL_ITEMS);

    public static ${EntityResource.className()} oneWithResourceId() {
        ${EntityResource.className()} item = new ${EntityResource.className()}();
        item.setResourceId("zyxwvutsrqponmlkjihgfedcba9");
        item.setText("sample text");
        return item;
    }

    public static ${EntityResource.className()} oneWithoutResourceId() {
        ${EntityResource.className()} item = new ${EntityResource.className()}();
        item.setText("sample text");
        return item;
    }

    public static ${EntityResource.className()} copyOf(${EntityResource.className()} source) {
        ${EntityResource.className()} copy = new ${EntityResource.className()}();
        copy.setResourceId(source.getResourceId());
        copy.setText(source.getText());
        return copy;
    }

    public static List<${EntityResource.className()}> allItems() {
        List<${EntityResource.className()}> list = new ArrayList<>();
        list.add(oneWithResourceId());
        ${EntityResource.className()} second = new ${EntityResource.className()}();
        second.setResourceId("bcdefghijklmnopqrstuvwxyz12");
        second.setText("another text");
        list.add(second);
        return list;
    }

    public static List<${EntityResource.className()}> allItemsWithSameText() {
        List<${EntityResource.className()}> list = new ArrayList<>();
        final String sameText = "repeated text value";
        for (int i = 0; i < 3; i++) {
            ${EntityResource.className()} item = new ${EntityResource.className()}();
            item.setText(sameText);
            list.add(item);
        }
        return list;
    }
}
